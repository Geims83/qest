FROM mcr.microsoft.com/dotnet/sdk:6.0 as build

COPY ./src ./src
RUN dotnet publish /src/qest/ -o /qest --runtime linux-x64 -c Release --self-contained true /p:PublishSingleFile=true /p:PublishTrimmed=true

FROM mcr.microsoft.com/mssql/server:2019-latest AS mssql
USER root

# env vars needed by the mssql image
ENV ACCEPT_EULA Y
ENV SA_PASSWORD qestDbSecurePassword27!
#
#ENV DACPAC


WORKDIR /qest
COPY --from=build /qest/qest .

RUN chmod a+x qest

# sqlpackage
RUN apt-get update \
    && apt-get install unzip -y

RUN wget -O sqlpackage.zip https://go.microsoft.com/fwlink/?linkid=2143497
RUN unzip sqlpackage.zip
RUN chmod a+x sqlpackage

# Launch SQL Server, confirm startup is complete, deploy the DACPAC, run tests.
# See https://stackoverflow.com/a/51589787/488695
ENTRYPOINT ["sh", "-c", "( /opt/mssql/bin/sqlservr & ) | grep -q \"Service Broker manager has started\" \
    && ./sqlpackage /a:Publish /sf:db/${DACPAC}.dacpac /tsn:. /tdn:$DACPAC /tu:sa /tp:$SA_PASSWORD \
    && ./qest --folder tests --tcs \"Server=localhost,1433;Initial Catalog=${DACPAC};User Id=sa;Password=${SA_PASSWORD}\""]