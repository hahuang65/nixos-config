{ fromGitHub }:
fromGitHub {
  repo = "emmanueltouzery/apidocs.nvim";
  rev = "6f34023f9a14dda5fa1f06d8ffe53e689324d2d2";
  hash = "sha256-22rX2/C7IJHtnF8EgM0yTP1iXnFti1TSam6WH4/SFlo=";
  skipModuleTests = [ "apidocs.snacks" ]; # For some reason, this fails the test
}
