#!/bin/bash

nscd -i passwd
nscd -i group

echo "Ldap Cache Cleared!"