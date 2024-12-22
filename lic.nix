# adapted from https://nixos.wiki/wiki/Nix_Cookbook

let
  allowedLicenses = [
    "MIT-like"
    "apple-psl20"
    "asl20"
    "asl20,cc0"
    "asl20,mit"
    "asl20,vim"
    "boost"
    "bsd0"
    "bsd2"
    "bsd2,bsd3,apple-psl10"
    "bsd2,bsd3,cc0,lgpl21Plus,lgpl2Plus,mit,mit0,ofl,publicDomain"
    "bsd2,gpl2"
    "bsd2,gpl2Plus"
    "bsd2,gpls2"
    "bsd2Patent"
    "bsd3"
    "bsd3,gpl2Plus"
    "bsd3,publicDomain"
    "bsdOriginal"
    "curl"
    "gpl2"
    "gpl2Only"
    "gpl2Only,bsd2,lgpl21"
    "gpl2Only,gpl2Plus,gpl3Plus,lgpl21Plus,bsd3,bsdOriginalUC,publicDomain"
    "gpl2Only,lgpl21Only"
    "gpl2Only,lgpl3Plus,gpl3Plus"
    "gpl2Plus"
    "gpl2Plus,lgpl21Plus"
    "gpl2Plus,lgpl2Plus,bsd3,mit"
    "gpl3"
    "gpl3Only"
    "gpl3Plus"
    "isc"
    "lgpl21"
    "lgpl21,bsd2"
    "lgpl21Only"
    "lgpl21Plus"
    "lgpl21Plus,gpl2Plus"
    "lgpl2Plus"
    "lgpl3Only,gpl2Only"
    "lgpl3Plus"
    "lgpl3Plus,gpl2Plus,gpl3Plus"
    "libpng2"
    "mit"
    "mit,bsd1,bsd3,gpl3Only,asl20"
    "mit,isc,bsd2,bsd3,cc-by-40"
    "ncsa"
    "openssl"
    "psfl"
    "publicDomain"
    "publicDomain,bsdOriginal,bsd0,bsd3,gpl3,isc,openssl"
    "sleepycat"
    "unlicense,mit"
    "zlib"
  ];
in rec {
  # Incomplete list, customize to your policies.
  permissiveLicense = v: let isAllowed = builtins.elem v.license allowedLicenses; in
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
