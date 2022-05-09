# Author: Shahruk Hossain <shahruk10@gmail.com>
# Year: 2022
#
# py38.nix - Python 3.8.x environment.

import ./pycuda_common.nix {
  python_version = "38";
  gcc_version = "9";
}
