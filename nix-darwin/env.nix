let
  user = "iam";
  hostname = "colearn";
  arch = "aarch64";
in
{
  inherit user hostname;
  system = "${arch}-darwin";
}
