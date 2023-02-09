/* { stdenv, sources }: */
{ stdenv, fetchFromGitHub }:
stdenv.mkDerivation {
  /* inherit (sources.git-credential-manager) pname version src; */

  pname = "git-credential-manager";
  version = "v2.0.886";
  src = fetchFromGitHub ({
    owner = "GitCredentialManager";
    repo = "git-credential-manager";
    rev = "v2.0.886";
    fetchSubmodules = false;
    sha256 = "sha256-zRjDdykb0WD+2HoyvTJawBMKlCfm3Aoig76IDiBdVA0=";
  });


  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    cp -r . $out
  '';
}
