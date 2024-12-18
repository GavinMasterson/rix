% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/renv_helpers.R
\name{renv2nix}
\alias{renv2nix}
\title{renv2nix}
\usage{
renv2nix(
  renv_lock_path = "renv.lock",
  return_rix_call = FALSE,
  method = c("fast", "accurate"),
  override_r_ver = NULL,
  ...
)
}
\arguments{
\item{renv_lock_path}{Character, path of the renv.lock file, defaults to
"renv.lock"}

\item{return_rix_call}{Logical, return the generated rix function call
instead of evaluating it this is for debugging purposes, defaults to
\code{FALSE}}

\item{method}{Character, the method of generating a nix environment from an
renv.lock file. "fast" is an inexact conversion which simply extracts the R
version and a list of all the packages in an renv.lock file and adds them
to the \code{r_pkgs} argument of \code{rix()}. This will use a snapshot of \code{nixpkgs}
that should contain package versions that are not too different from the
ones defined in the \code{renv.lock} file. For packages installed from Github or
similar, an attempt is made to handle them and pass them to the \code{git_pkgs}
argument of \code{rix()}. Currently defaults to "fast", "accurate" is not yet
implemented.}

\item{override_r_ver}{Character defaults to NULL, override the R version
defined in the \code{renv.lock} file with another version. This is especially
useful if the \code{renv.lock} file lists a version of R not (yet) available
through Nix.}

\item{...}{
  Arguments passed on to \code{\link[=rix]{rix}}
  \describe{
    \item{\code{system_pkgs}}{Vector of characters. List further software you wish to
install that are not R packages such as command line applications for
example. You can look for available software on the NixOS website
\url{https://search.nixos.org/packages?channel=unstable&from=0&size=50&sort=relevance&type=packages&query=} # nolint}
    \item{\code{local_r_pkgs}}{List. A list of local packages to install. These packages
need to be in the \code{.tar.gz} or \code{.zip} formats and must be in the same
folder as the generated "default.nix" file.}
    \item{\code{tex_pkgs}}{Vector of characters. A set of TeX packages to install. Use
this if you need to compile \code{.tex} documents, or build PDF documents using
Quarto. If you don't know which package to add, start by adding "amsmath".
See the Vignette "Authoring LaTeX documents" for more details.}
    \item{\code{ide}}{Character, defaults to "other". If you wish to use RStudio to work
interactively use "rstudio" or "rserver" for the server version. Use "code"
for Visual Studio Code. You can also use "radian", an interactive REPL. For
other editors, use "other". This has been tested with RStudio, VS Code and
Emacs. If other editors don't work, please open an issue.}
    \item{\code{project_path}}{Character. Where to write \code{default.nix}, for example
"/home/path/to/project". The file will thus be written to the file
"/home/path/to/project/default.nix". If the folder does not exist, it will
be created.}
    \item{\code{overwrite}}{Logical, defaults to FALSE. If TRUE, overwrite the
\code{default.nix} file in the specified path.}
    \item{\code{print}}{Logical, defaults to FALSE. If TRUE, print \code{default.nix} to
console.}
    \item{\code{message_type}}{Character. Message type, defaults to \code{"simple"}, which
gives minimal but sufficient feedback. Other values are currently \verb{"quiet},
which generates the files without message, and \code{"verbose"}, displays all
the messages.}
    \item{\code{shell_hook}}{Character of length 1, defaults to \code{NULL}. Commands added
to the \code{shellHook} variable are executed when the Nix shell starts. So by
default, using \verb{nix-shell default.nix} will start a specific program,
possibly with flags (separated by space), and/or do shell actions. You can
for example use \code{shell_hook = R}, if you want to directly enter the declared
Nix R session when dropping into the Nix shell. @details This function will
write a \code{default.nix} and an \code{.Rprofile} in the chosen path. Using the Nix
package manager, it is then possible to build a reproducible development
environment using the \code{nix-build} command in the path. This environment will
contain the chosen version of R and packages, and will not interfere with any
other installed version (via Nix or not) on your machine. Every dependency,
including both R package dependencies but also system dependencies like
compilers will get installed as well in that environment.

It is possible to use environments built with Nix interactively, either
from the terminal, or using an interface such as RStudio. If you want to
use RStudio, set the \code{ide} argument to \code{"rstudio"}. Please be aware that
RStudio is not available for macOS through Nix. As such, you may want to
use another editor on macOS. To use Visual Studio Code (or Codium), set the
\code{ide} argument to \code{"code"}, which will add the \code{{languageserver}} R package
to the list of R packages to be installed by Nix in that environment. You
can use the version of Visual Studio Code or Codium you already use, or
also install it using Nix (by adding "vscode" or "vscodium" to the list of
\code{system_pkgs}). For non-interactive use, or to use the environment from the
command line, or from another editor (such as Emacs or Vim), set the \code{ide}
argument to \code{"other"}. We recommend reading the
\code{vignette("e-interactive-use")} for more details.

Packages to install from Github or Gitlab must be provided in a list of 3
elements: "package_name", "repo_url" and "commit". To install several
packages, provide a list of lists of these 3 elements, one per package to
install. It is also possible to install old versions of packages by
specifying a version. For example, to install the latest version of \code{{AER}}
but an old version of \code{{ggplot2}}, you could write: \code{r_pkgs = c("AER", "ggplot2@2.2.1")}. Note however that doing this could result in dependency
hell, because an older version of a package might need older versions of
its dependencies, but other packages might need more recent versions of the
same dependencies. If instead you want to use an environment as it would
have looked at the time of \code{{ggplot2}}'s version 2.2.1 release, then use
the Nix revision closest to that date, by setting \code{r_ver = "3.1.0"}, which
was the version of R current at the time. This ensures that Nix builds a
completely coherent environment. For security purposes, users that wish to
install packages from Github/Gitlab or from the CRAN archives must provide
a security hash for each package. \code{{rix}} automatically precomputes this
hash for the source directory of R packages from GitHub/Gitlab or from the
CRAN archives, to make sure the expected trusted sources that match the
precomputed hashes in the \code{default.nix} are downloaded. If Nix is
available, then the hash will be computed on the user's machine, however,
if Nix is not available, then the hash gets computed on a server that we
set up for this purposes. This server then returns the security hash as
well as the dependencies of the packages. It is possible to control this
behaviour using \code{options(rix.sri_hash=x)}, where \code{x} is one of "check_nix"
(the default), "locally" (use the local Nix installation) or "api_server"
(use the remote server to compute and return the hash).

Note that installing packages from Git or old versions using the \code{"@"}
notation or local packages, does not leverage Nix's capabilities for
dependency solving. As such, you might have trouble installing these
packages. If that is the case, open an issue on \code{{rix}}'s Github
repository.

By default, the Nix shell will be configured with \code{"en_US.UTF-8"} for the
relevant locale variables (\code{LANG}, \code{LC_ALL}, \code{LC_TIME}, \code{LC_MONETARY},
\code{LC_PAPER}, \code{LC_MEASUREMENT}). This is done to ensure locale
reproducibility by default in Nix environments created with \code{rix()}. If
there are good reasons to not stick to the default, you can set your
preferred locale variables via \verb{options(rix.nix_locale_variables = list(LANG = "de_CH.UTF-8", <...>)} and the aforementioned locale variable
names.

It is possible to use \verb{"bleeding_edge}" or \verb{"frozen_edge}" as the value for
the \code{r_ver} argument. This will create an environment with the very latest
R packages. \verb{"bleeding_edge}" means that every time you will build the
environment, the packages will get updated. This is especially useful for
environments that need to be constantly updated, for example when
developing a package. In contrast, \verb{"frozen_edge}" will create an
environment that will remain stable at build time. So if you create a
\code{default.nix} file using \verb{"bleeding_edge}", each time you build it using
\code{nix-build} that environment will be up-to-date. With \verb{"frozen_edge}" that
environment will be up-to-date on the date that the \code{default.nix} will be
generated, and then each subsequent call to \code{nix-build} will result in the
same environment. We highly recommend you read the vignette titled
"z - Advanced topic: Understanding the rPackages set release cycle and
using bleeding edge packages".}
  }}
}
\value{
Nothing, this function is called for its side effects only, unless
\code{return_rix_call = TRUE} in which case an unevaluated call to \code{rix()}
is returned
}
\description{
renv2nix
}
