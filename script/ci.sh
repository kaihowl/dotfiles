#!/bin/bash

function decorate() {
  sed -e 's/^.*deprecat.*$/::warning:: &/'
}

printf 'this line is fine\nbut this says something about a deprecation' | decorate
