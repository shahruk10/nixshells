# Author: Shahruk Hossain <shahruk10@gmail.com>
# Year: 2022
#
# py310.nix - Python 3.10.x environment.

import ./pycuda_common.nix {
  python_version = "310";
  gcc_version = "10";
}
