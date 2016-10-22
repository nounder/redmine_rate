# Redmine Rate

Agnostic [Redmine][0] plugin for billing users based on spent time and hourly
rates with UI and simple API for plugins.

 - Work cost calculated dynamicaly based on tracked time.
 - Hourly rates can be specified globally as well as on per project basis.
 - Cost and rates are persistent.
 - Historical data is preserved.
 - Managable by administrators as well as permitted users (*rate supervisors*).
 - UI for managing rates in user profile, project memberships, and global views.
 - Easily integrates with other plugins with simple and stable API (`Rate.for`).

This plugin is based on [Eric Davis'][3] awesome work which means it can be used
as drop-in replacement and it will work with all existing plugins using
`redmine_rate`.


## Installation

Follow standard Redmine plugin installation procedure.

 1. Move `redmine_rate/` to `$REDMINE/plugins/`
 2. Run migrations: `rake redmine:plugins:migrate NAME=redmine_rate`
 3. Restart Redmine.


## Usage

By defaults rates can by set only by administrator. If you would like to let
other users have access to it, select *Rate supervisor* group in plugin settings
(`Settings » Plugins » Redmine Rate`).

In addition to that, role permissions for project are provided:
 - *View rates* enabling to see cost for spent time and viewing project
   members' hourly rates.
 - *Edit rates* allowing to edit rates for a given project.

#### Specify rates

There are two main ways to manage rates:

 - **Project membership settings**, for user with *View rates* and *Edit rates*
    permissions.

   1. Go to project *Settings*.
   2. Select *Members* tab.
   3. Click *New rate* in user row.

 - **Rates view**, for administrators and supervisors, which query filters and
    global list.

   1. Go to user profile.
   2. Click *Rates*.
   3. Click `+` icon.

 - **User edit view**, for administrators, in *Rates* tab.

When creating new rate, it is possible to specify *Project* value. If it is set
as "Default rate", rates will be applied globally, otherwise only in the scope
of selected project.


## Requirements

The aim is to keep and mantain compatibility for as many Redmine versions as
possible. Currently tested and supported versions:

 - Redmine 2.x
 - Redmine 3.x


  [0]: http://www.redmine.org/
  [1]: http://www.redmine.org/projects/redmine/wiki/RedmineTimeTracking
  [3]: https://github.com/edavis10
