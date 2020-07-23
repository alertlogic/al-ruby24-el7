set -ex

# if local build, exit
if [ -z "${CODEBUILD_BUILD_IMAGE}" ]; then
  exit 0
fi

# download latest external dependancies
mkdir -p RPMS/{x86_64,noarch}/
yumdownloader --destdir=RPMS/x86_64/ \
  rh-ruby24-rubygem-psych \
  rh-ruby24-ruby-libs \
  rh-ruby24-rubygem-did_you_mean \
  rh-ruby24-rubygem-io-console \
  rh-ruby24-ruby \
  rh-ruby24-ruby-devel \
  rh-ruby24-runtime \
  rh-ruby24-rubygem-json \
  rh-ruby24-rubygem-bigdecimal \
  rh-ruby24-rubygem-openssl

yumdownloader --destdir=RPMS/noarch/ \
  rh-ruby24-ruby-irb \
  rh-ruby24-rubygem-rdoc \
  rh-ruby24-rubygems \
  rh-ruby24-rubygems-devel

# upload files
DISTRIBUTION="el7"
RELEASE_DIRS="dev"
# if production release, add prod
if [ ! -z "${PROD_RELEASE}" ]; then
  RELEASE_DIRS="${RELEASE_DIRS} prod"
fi
for RELEASE_DIR in $RELEASE_DIRS; do
  for DIR in RPMS SRPMS SPECS SOURCES; do
    aws s3 cp --recursive ./${DIR}/ s3://${S3REPOBUCKET}/${RELEASE_DIR}/${DISTRIBUTION}/${DIR}/
  done
done
