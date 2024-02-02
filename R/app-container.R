#' Setup shinylive assets
#'
#' Call before \link{create_shinylive_container}.
#'
#' @export
#' @import shinylive
setup_shinylive_pkgdown <- function() {
  if (!file.exists("./_pkgdown.yml")) {
    stop("Please call usethis::use_pkgdown to set up your package website.")
  }
  if (!dir.exists("./docs")) {
    stop("Please run pkgdown::build_site() at least once.")
  }

  assets_path <- "./docs/shinylive-assets"
  if (!dir.exists(assets_path)) {
    dir.create(assets_path)
    # Copy assets + cleanup unwanted files
    export(
      system.file("examples", "01_hello", package = "shiny"),
      assets_path
    )
    to_remove <- paste(
      assets_path,
      c("app.json", "index.html", "edit"),
      sep = "/"
    )
    unlink(to_remove, recursive = TRUE)
    message(
      sprintf(
        "shinylive assets for pkgdown created in %s",
        assets_path
      )
    )
  }
}



#' Create a container for shinylive application
#'
#' Allows to embed a shinylive standalone app into a pkgdown website.
#' Importantly, you need to serve the website to preview the applications.
#' This won't work with the classic pkgdown local browser. The best way to do so
#' is either to use \code{httpuv::runStaticServer("<SITE_PATH>")} or use the
#' `go live` VSCode extension.
#'
#' @param app_json_path app_path App location. We call shinylive::export
#' to create a JSON file which is then forwarded to shinylive. This only works
#' if your app is within a directory and not created from a R function.
#' @param id Unique container id.
#' @param mode shinylive app configuration. Display either the app, the app +
#' code editor + terminal.
#' @param height Container height. Expect a valid CSS unit like `800px`.
#' @return A tag list.
#' @importFrom shiny tagList tags validateCssUnit singleton
#' @importFrom bslib card
#' @importFrom shinylive export
#' @export
create_shinylive_container <- function(
  app_path,
  id,
  mode = c("viewer", "editor-terminal-viewer"),
  height = NULL
) {

  root <- ".."
  assets_root <- sprintf("%s/docs/shinylive-assets", root)
  app_path <- sprintf("../%s", app_path)
  mode <- match.arg(mode)

  app_name <- tail(strsplit(app_path, "/")[[1]], n = 1)
  # shinylive::export is clever enough to only copy the
  # shinylive assets when they don't exist!
  export(app_path, assets_root, subdir = app_name)
  # Move SW root of pkgdown website but only once
  try({
    file.rename(
      sprintf("%s/shinylive-sw.js", assets_root),
      "../docs/shinylive-sw.js"
    )
  })

  json_path <- sprintf("../shinylive-assets/%s/app.json", app_name)

  tagList(
    # Load SW only once ...
    singleton(
      tags$script(
        src = "../shinylive-assets/shinylive/load-shinylive-sw.js",
        type = "module"
      )
    ),
    singleton(
      tags$link(
        href = "../shinylive-assets/shinylive/shinylive.css",
        rel = "stylesheet"
      )
    ),
    tags$script(
      type = "module",
      sprintf(
        "import { runApp } from '../shinylive-assets/shinylive/shinylive.js';
        const response = await fetch('%s');
        if (!response.ok) {
          throw new Error('HTTP error loading app.json: ' + response.status);
        }
        const appFiles = await response.json();

        const appRoot = document.getElementById('%s');
        runApp(appRoot, '%s', {startFiles: appFiles}, 'r');
        ",
        json_path,
        id,
        mode
      )
    ),
    card(
      id = id,
      full_screen = TRUE,
      height = validateCssUnit(height)
    )
  )
}
