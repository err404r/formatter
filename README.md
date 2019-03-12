Custom formater for RSpec

The easiest way to solve this task was to fork https://github.com/sj26/rspec_junit_formatter/ and change it.
But this repo don't use any xml lib for building xml, so I decided to write my own xml builder.
Also this aproach better for demonstarting my skills. But I used unit tests from the repo above because they cover triky cases with unicode charactres.
For building JUnit xml I found xml schema(http://windyroad.com.au/dl/Open%20Source/JUnit.xsd) and modify it, to fit the task requirement.

TODO:
- Add unit tests for properties section
- Improve test failure error message
