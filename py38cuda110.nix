# Author: Shahruk Hossain <shahruk10@gmail.com>
# Year: 2022
#
# py38cuda110.nix - Python 3.8.x environment with CUDA v11.0.

import ./pycuda_common.nix {
  python_version = "38";
  gcc_version = "9";
  cuda_version = "11_0";
  cudnn_version = "8_1";
}
