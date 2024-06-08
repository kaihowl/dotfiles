with rec {
  # Incomplete list, customize to your policies.
  permissiveLicense = v: v.license == "bsd3" || v.license == "mit" || v.license == "bsd2" || v.license == "publicDomain" || v.license == "asl20" || v.license == "zlib" || v.license == "bsdOriginal" || v.license == "openssl";

  # Omit some false-positive buildInputs like bash and perl.. those should be nativeBuildInputs rather?
  saneDep = d: d ? meta.license
      && builtins.substring 0 5 d.name != "bash-"
      && builtins.substring 0 5 d.name != "perl-";

  # Keep if the license is not allowed, or if has any (transitive) dep with a license that is not allowed.
  keepBadDeps = ds: builtins.filter (n: (permissiveLicense n) || n.baddeps != []) (map derivToNode (builtins.filter saneDep ds));

  derivToNode = d: 
    { license = if builtins.typeOf d.meta.license == "string" 
                then d.meta.license
                else if builtins.typeOf d.meta.license == "list"  # can happen sometimes, could concat.. but have a look rather
                     then "MULTI"
                     else d.meta.license.shortName;
      name = d.name;
      baddeps = keepBadDeps (builtins.filter saneDep d.buildInputs);
    };
};
let fl = (import ./flake.nix) {
  src =  ./.;
}.defaultNix;
    ps = fl{}.defaultNix;
in keepBadDeps ps


###
# let
#   getLicensesRecursivly = pkg: [
#     # TODO: Generate a list of these, for all inputs, recursively
#     {
#       inherit (pkg) pname version;
#       inherit (pkg.meta) license;
#     }
#   ];
#   ourLicensesJSON = builtins.toJSON (getLicensesRecursivly ourPackage);
#   # where pkgs is Nixpkgs
#   inherit (pkgs) lib;
# in ourLicenses = stdenvNoCC.mkDerivation {
#   pname = "licenses";
#   inherit version;
#   buildCommand = ''
#     mkdir $out
#     echo ${lib.escapeShellArg ourLicensesJSON} > $out/licenses.json
#   ''; ourPackage;
# };
