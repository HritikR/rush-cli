import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:dart_casing/dart_casing.dart';

/// Generate arguments for the Ant exec.
class AntArgs {
  final String dataDirPath;
  final String cd;
  final String org;
  final String version;
  final String name;

  AntArgs(
    this.dataDirPath,
    this.cd,
    this.org,
    this.version,
    this.name,
  );

  List toList(String task) {
    final args = <String>[];
    final workspaces = p.join(dataDirPath, 'workspaces');
    final baseDir = p.dirname(p.dirname(Platform.script.path));

    args.add(
        '-buildfile=${p.joinAll([...baseDir.split('/'), 'tools', 'apache-ant', 'build.xml'])}');
    args.add(
        '-DantCon=${p.joinAll([...baseDir.split('/'), 'tools', 'ant-contrib-1.0b3.jar'])}');

    if (task == 'javac') {
      args.add('javac');
      args.add('-Dclasses=${p.join(workspaces, org, 'classes')}');
      args.add('-DextSrc=${p.join(cd, 'src')}');
      args.add('-Droot=$cd');
      args.add('-DextName=${Casing.pascalCase(name)}');
      args.add('-Dorg=$org');
      args.add('-Dversion=$version');
      args.add('-DdevDeps=${p.join(cd, '.rush', 'dev_deps')}');
      args.add('-Ddeps=${p.join(cd, 'deps')}');
      args.add('-Dprocessor=${p.joinAll([...baseDir.split('/'), 'tools', 'processor'])}');
    } else if (task == 'process') {
      args.add('jarExt');
      args.add('-Dprocessor=${p.joinAll([...baseDir.split('/'), 'tools', 'processor'])}');
      args.add('-Dclasses=${p.join(workspaces, org, 'classes')}');
      args.add('-Draw=${p.join(workspaces, org, 'raw')}');
      args.add('-DrawCls=${p.join(workspaces, org, 'raw-classes')}');
      args.add('-DdevDeps=${p.join(cd, '.rush', 'dev_deps')}');
      args.add('-Ddeps=${p.join(cd, 'deps')}');
      args.add('-Dextension=$org');
      args.add('-Dcd=$cd');
    } else if (task == 'dex') {
      args.add('dexExt');
      args.add('-Dextension=$org');
      args.add('-Ddexer=${p.joinAll([...baseDir.split('/'), 'tools', 'dx.jar'])}');
      args.add('-Draw=${p.join(workspaces, org, 'raw')}');
      args.add('-DrawCls=${p.join(workspaces, org, 'raw-classes')}');
    } else if (task == 'assemble') {
      args.add('assemble');
      args.add('-Dout=${p.join(cd, 'out')}');
      args.add('-Dextension=$org');
      args.add('-Draw=${p.join(workspaces, org, 'raw')}');
    }

    return args;
  }
}
