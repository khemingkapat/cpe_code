{
  buildPythonPackage,
  fetchPypi,
  hatch-nodejs-version,
  hatch-jupyter-builder,
  hatchling,
  jupyterlab,
}:

buildPythonPackage rec {
  pname = "jupyterlab-vim";
  version = "4.1.4";
  pyproject = true;

  src = fetchPypi {
    pname = "jupyterlab_vim";
    inherit version;
    hash = "sha256-q/KJGq+zLwy5StmDIa5+vL4Mq+Uj042A1WnApQuFIlo=";
  };

  build-system = [
    hatch-nodejs-version
    hatchling
    jupyterlab
  ];

  dependencies = [
    hatch-jupyter-builder
    jupyterlab
  ];

  pythonImportsCheck = [
    "jupyterlab_vim"
  ];
}
