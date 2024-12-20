# respdetect

### Summary

<img align="right" src="images/gm_image.png" alt="drawing" width="400"/>

Respdetect is a MATLAB toolkit to detect respirations in whale DTAG or CATS tag records. The tools are especially useful for detecting respiration events using movement signatures in logging whales, in addition to single-breath surfacings. Respdetect exports the locations and type (single-breath surfacing or logging) of all detected breaths.

These files are intended to work alongside the DTAG Matlab Toolboxes by Mark Johnson which can be found [here](https://github.com/stacyderuiter/dtagtools.git). The DTAG Matlab toolbox is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version. This software is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details. You should have received a copy of the GNU General Public License along with D3. If not, see <http://www.gnu.org/licenses/>.

## Installation
### System Requirements
Respdetect was developed and tested on 64-bit Windows 10 and has not yet been tested on other platforms.

### MATLAB
Respdetect was developed on MATLAB versions R2020a and has not yet been tested with other versions.

MATLAB toolbox dependencies:

1. Audio Toolbox
2. Signal Processing Toolbox
3. Image Processing Toolbox
4. Statistics and Machine Learning Toolbox

### Installation Instructions
You may either 1) directly download this repository or 2) clone it using: git clone https://github.com/ashleyblawas/respdetect.git.

When you open the `main.m` file you will see that the first step steps up your directories. This setup is detailed in the repository Wiki [here](https://github.com/ashleyblawas/respdetect/wiki/3.-Setup). You will need to edit a `paths.txt` file which you will be prompted to select to designate the path of your tools and your data. After running the first step of `main.m,` the `respdetect` tools will be on your path and no further installation is needed. 

**Keep in mind that you will need to have the [DTAG Tools](https://github.com/stacyderuiter/dtagtools.git) installed to work with the `respdetect` scripts.**

## [Usage](https://github.com/ashleyblawas/respdetect/wiki)
Check out the repository Wiki (linked above and to screenshot below) for detailed instructions on how to use these tools. The ``main.m`` script will guide you through the use of the tools.

[![The home page of the repository Wiki.](images/wiki_screenshot.png)](https://github.com/ashleyblawas/respdetect/wiki).

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License
[GNU](https://choosealicense.com/licenses/gpl-3.0/)
<br>
