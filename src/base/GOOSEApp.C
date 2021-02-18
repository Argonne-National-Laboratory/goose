#include "GOOSEApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "ModulesApp.h"
#include "MooseSyntax.h"

InputParameters
GOOSEApp::validParams()
{
  InputParameters params = MooseApp::validParams();

  // Do not use legacy DirichletBC, that is, set DirichletBC default for preset = true
  params.set<bool>("use_legacy_dirichlet_bc") = false;

  return params;
}

GOOSEApp::GOOSEApp(InputParameters parameters) : MooseApp(parameters)
{
  GOOSEApp::registerAll(_factory, _action_factory, _syntax);
}

GOOSEApp::~GOOSEApp() {}

void
GOOSEApp::registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  ModulesApp::registerAll(f, af, s);
  Registry::registerObjectsTo(f, {"GOOSEApp"});
  Registry::registerActionsTo(af, {"GOOSEApp"});

  /* register custom execute flags, action syntax, etc. here */
}

void
GOOSEApp::registerApps()
{
  registerApp(GOOSEApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
extern "C" void
GOOSEApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  GOOSEApp::registerAll(f, af, s);
}
extern "C" void
GOOSEApp__registerApps()
{
  GOOSEApp::registerApps();
}
