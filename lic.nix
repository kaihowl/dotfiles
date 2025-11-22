# adapted from https://nixos.wiki/wiki/Nix_Cookbook

let
  # Individual licenses that are allowed
  # Licenses are checked individually, so multi-licensed packages are allowed
  # if ALL their licenses are in this list
  allowedLicenses = [
    "MIT-like"
    "apple-psl10"
    "apple-psl20"
    "asl20"
    "boost"
    "bsd0"
    "bsd1"
    "bsd2"
    "bsd2Patent"
    "bsd3"
    "bsdOriginal"
    "bsdOriginalUC"
    "cc-by-40"
    "cc0"
    "curl"
    "gpl2"
    "gpl2Only"
    "gpl2Plus"
    "gpl3"
    "gpl3Only"
    "gpl3Plus"
    "gpls2"  # Possibly a typo, but kept for compatibility
    "isc"
    "lgpl21"
    "lgpl21Only"
    "lgpl21Plus"
    "lgpl2Plus"
    "lgpl3Only"
    "lgpl3Plus"
    "libpng2"
    "llvm-exception"
    "mit"
    "mit0"
    "ncsa"
    "ofl"
    "openssl"
    "psfl"
    "publicDomain"
    "sleepycat"
    "unlicense"
    "vim"
    "zlib"
  ];
in rec {
  # Check if a license string (either single or comma-separated list) is allowed
  # All individual licenses in a multi-license package must be in allowedLicenses
  licenseAllowed = licenseStr:
    let
      licenses = builtins.filter builtins.isString (builtins.split "," licenseStr);
    in
      builtins.all (lic: builtins.elem lic allowedLicenses) licenses;

  # Incomplete list, customize to your policies.
  permissiveLicense = v: let isAllowed = licenseAllowed v.license; in
    if !isAllowed
    then builtins.trace ("non-allowed license found: " + v.name + ", " + v.license) isAllowed
    else isAllowed;

  # Omit some false-positive buildInputs like bash and perl.. those should be nativeBuildInputs rather?
  saneDep = d: d ? meta.license
      && builtins.substring 0 5 d.name != "bash-"
      && builtins.substring 0 5 d.name != "perl-";

  # Keep if the license is not allowed, or if has any (transitive) dep with a license that is not allowed.
  keepBadDeps = ds: builtins.filter (n: !(permissiveLicense n) || n.baddeps != []) (map derivToNode (builtins.filter saneDep ds));

  mapLicense = d:
    if builtins.typeOf d.meta.license == "string"
    then d.meta.license
    else if builtins.typeOf d.meta.license == "list"
          # Concat licenses instead of printing MULTI
          then builtins.concatStringsSep "," (map (d: d.shortName) d.meta.license)
          else d.meta.license.shortName;

  derivToNode = d:
    { license = mapLicense d;
      name = d.name;
      baddeps = keepBadDeps (builtins.filter saneDep d.buildInputs);
    };
}
