{
  description = "Dev Templates";

  outputs =
    { self }:
    {
      templates = {
        python = {
          path = ./python/default;
          description = "Python dev shell (CPU + CUDA)";
        };
      };
    };
}
