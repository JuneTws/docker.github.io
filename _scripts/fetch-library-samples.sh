#!/usr/bin/env bash

# Get the Library docs
svn co https://github.com/docker-library/docs/trunk ./_samples/library || (echo "Failed library download" && exit 1)
# Remove symlinks to maintainer.md because they break jekyll and we don't use em
find ./_samples/library -maxdepth 9  -type l -delete
# Remove the top-level README because we don't want to generate a file for that
rm ./_samples/library/README.md
# Loop through the README.md files, turn them into rich index.md files
FILES=$(find ./_samples/library -type f -name 'README.md')
for f in ${FILES}
do
  curdir=$(dirname "${f}")
  justcurdir="${curdir##*/}"
  if [ -e ${curdir}/README-short.txt ]
  then
    shortrm=$(cat ${curdir}/README-short.txt)
  fi
  echo "Adding front-matter to ${f} ..."
  echo --- >> ${curdir}/front-matter.txt
  echo title: "${justcurdir}" >> ${curdir}/front-matter.txt
  echo keywords: library, sample, ${justcurdir} >> ${curdir}/front-matter.txt
  echo repo: "${justcurdir}" >> ${curdir}/front-matter.txt
  echo layout: docs >> ${curdir}/front-matter.txt
  echo permalink: /samples/library/${justcurdir}/ >> ${curdir}/front-matter.txt
  echo hide_from_sitemap: true >> ${curdir}/front-matter.txt
  echo redirect_from: >> ${curdir}/front-matter.txt
  echo - /samples/${justcurdir}/ >> ${curdir}/front-matter.txt
  echo description: \| >> ${curdir}/front-matter.txt
  echo \ \ ${shortrm} >> ${curdir}/front-matter.txt
  echo --- >> ${curdir}/front-matter.txt
  echo >> ${curdir}/front-matter.txt
  echo ${shortrm} >> ${curdir}/front-matter.txt
  echo >> ${curdir}/front-matter.txt
  if [ -e ${curdir}/github-repo ]
  then
    # gitrepo=$(<${curdir}/github-repo)
    gitrepo=$(cat ${curdir}/github-repo)
    echo >> ${curdir}/front-matter.txt
  fi
  cat ${curdir}/front-matter.txt > ${curdir}/../${justcurdir}.md
  echo {% include library-samples.md %} >> ${curdir}/../${justcurdir}.md
done

# Remove all files and subdirectory, except for the Markdown files we generated
find ./_samples/library/ ! -name 'library' -type d -exec rm -rf {} +
find ./_samples/library/ ! -name '*.md' -type f -exec rm -f {} +
