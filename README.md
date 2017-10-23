# fstep

#### Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with fstep](#setup)
    * [Setup requirements](#setup-requirements)
    * [Beginning with fstep](#beginning-with-fstep)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

The fstep module lets you use Puppet to install and configure the Food Security TEP
service infrastructure.

[FS-TEP](https://github.com/cgi-eoss/fstep) is an open platform for the food security
community to access and exploit EO data. This Puppet module may be used to
set up the various components including the community hub, the FS-TEP webapp,
and the processing manager.

**Note:** Currently this module is only compatible with CentOS 6.

**<span style="color:red;">Warning:</span>** This module is incomplete.

## Setup

### Setup Requirements

* This module may manage a yum repository for package installation with the
  parameter `fstep::repo::location`. This may be the URL of a hosted repo, or
  an on-disk path to a static repo (e.g. built with `createrepo`) in the format
  `file:///path/to/fsteprepo/$releasever/local/$basearch`. The latter is useful
  for standalone `puppet apply` deployments.

## Usage

The fstep module may be used to install the FS-TEP components individually by the
classes:
* `fstep::db`
* `fstep::drupal`
* `fstep::geoserver`
* `fstep::monitor`
* `fstep::proxy`
* `fstep::resto`
* `fstep::server`
* `fstep::webapp`
* `fstep::worker`
* `fstep::wps`
* `fstep::broker`

Configuration parameters shared by these classes may be set via `fstep::globals`.

Interoperability between the components is managed via hostnames, which may be
resolved at runtime via DNS or manually, by overriding the `fstep::globals::hosts_override`
hash. See the `fstep::globals` class for available parameters, and the specific
component classes for how these are used, for example in `apache::vhost`
resources.

### Manual configuration actions

Some components of FS-TEP are not fully instantiated by this Puppet module.
Following the automated provisioning of an FS-TEP environment, some manual steps
must be carried out to ensure full functionality of some components. These may
be omitted when some functionality is not required.

The following list describes some of these possible post-installation actions:
* `fstep::drupal`: Drupal site initialisation &amp; content restoration
* `fstep::monitor`: Creation of graylog inputs &amp; dashboards
* `fstep::monitor`: Creation of grafana dashboards
* `fstep::worker`: Installation of downloader credentials
* `fstep::wps`: Restoration &amp; publishing of default FS-TEP services


## Limitations

This module currently only targets installation on CentOS 6 nodes.
