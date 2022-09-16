﻿namespace TestBase
{
    public class TestStep
    {
        public string Name { get; set; }
        public TestCommand Command { get; set; }
        public ResultGroup Results { get; set; }
        public List<Assert>? Asserts { get; set; }
    }
}
