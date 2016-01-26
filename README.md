# haxe-configurator
[![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square)](https://github.com/FuzzyWuzzie/haxe-configurator/blob/master/LICENSE)

A JSON-based configuration loader, based on the idea that [**You deserve great error messages!**](http://www.ilikebigbits.com/blog/2016/1/25/you-deserve-great-error-messages).

Basically, [Emil](http://www.ilikebigbits.com/)'s premise is that the dev world is made far simpler by including specific, detailed, easy-to-understand error messages when things go wrong; and in general the tools we use to parse and process of configuration files are sorely lacking in that respect. He event went on make a great [C++ header library](http://www.ilikebigbits.com/blog/2016/1/25/configuru) which parses JSON, and is *noisy* about that process. Meaning: if there is a parse error, it will tell you exactly what went wrong and where; if there is an unexpected value (for example, a float instead of the expected bool), it will tell you; if you included something in your JSON file that the program never used, it will you; etc.

So why this library? Well, C++ is great and all.. but I really want to use these concepts in [Haxe](http://haxe.org/) so that they can be used wherever. This isn't a direct migration of code; rather this is my (currently) somewhat limited take on those concepts, implemented in Haxe.