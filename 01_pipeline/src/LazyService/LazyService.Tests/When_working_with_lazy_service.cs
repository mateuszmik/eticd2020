using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using NUnit.Framework;

namespace LazyService.Tests
{
    [TestFixture]
    public class When_working_with_lazy_service
    {
        [Test]
        public void want_to_make_sure_that_test_that_does_nothing_works()
        {
            Thread.Sleep(1000);
        }

        [Test]
        public void want_to_make_sure_that_quick_test_that_does_nothing_works_as_well()
        {
            Thread.Sleep(100);
        }

        [Test]
        public void check_if_long_test_that_does_nothing_works_as_well()
        {
            Thread.Sleep(3000);
            Assert.That(true);
        }
    }
}
