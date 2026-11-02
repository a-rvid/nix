let
  admin = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOYflayqclaYClYzK2VpBNNnvTDYQqyyPuFvwL2ywcn8";
in
{
  "secrets/common.age".publicKeys = [ admin ];
}
