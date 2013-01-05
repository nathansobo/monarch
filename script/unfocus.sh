find . -name *spec.coffee | xargs sed -E -i "" "s/f+(it|describe) +(['\"])/\\1 \\2/g"
