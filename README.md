# MPP Converter (Salesforce Application)

## Overview

Contains custom objects to hold Project information

    * Project
    * Task
    * Resource
    * Assignment
    * Milestone

Relied on java application (mppconverter) to do the actual convertion, this
application will only act as the front-end from Salesforce Side


## Installation

Using Ant Build Script (assumed that ant-salesforce.jar installed in your machine, otherwise see [here](http://www.salesforce.com/us/developer/docs/apexcode/Content/apex_deploying_ant.htm))

    __change the sf.username and sf.password for deployed org__

    $ ant deploy

Using unmanaged package [here](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tE0000000UskR)

## Configuration / Setup

    Setup -> Apps -> Connected Apps (New)

[See More about Force.com Remote Access](http://wiki.developerforce.com/page/Getting_Started_with_the_Force.com_REST_API)

Utilize OAuth authentication for the java application to work, so some information needs to be entered

    Callback URL : <application_host>/oauth/_callback

It allow to use http://localhost:8080 as application host if it is done from own machine (locally). See the
java application for more info
[https://github.com/smulyono/mppconverter-java](https://github.com/smulyono/mppconverter-java)


