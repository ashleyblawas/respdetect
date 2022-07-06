# respdetect

A Matlab toolkit to detect respirations in DTAG records.

These files are intended to work alongside the D3 Matlab Toolboxes by Mark Johnson.

The D3 Matlab toolbox is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version.

This software is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with D3. If not, see <http://www.gnu.org/licenses/>.

## Installation

Download the folder "resp_detect" into the directory of your choice. Then within MATLAB, open ``main.m``. 

Change the ``tool_path`` and ``data_path`` to reflect where these tools and your data are stored locally. 
Run the ``%% Load tools`` block to add the tools and data to your path.

```matlab
%% Load tools
tools_path = 'C:\Users\me\Dropbox\Graduate\Toolboxes\resp_detect';
data_path = 'D:\pilot_whales';

addpath(genpath(tools_path)); %Add all of your tools to the path
addpath(genpath(data_path)); %Add all of your data to the path
```

## Usage

The ``main.m`` script will guide you through the use of these tools. A .pdf file describing their use is coming soon!

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License
[GNU](https://choosealicense.com/licenses/gpl-3.0/)
<br>
