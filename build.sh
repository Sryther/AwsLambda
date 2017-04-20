yum -y update
yum -y install git cmake gcc-c++ gcc python-devel python27-virtualenv chrpath zip
mkdir -p /outputs/lambda-package/cv2 /outputs/build/numpy

# Build numpy
/usr/bin/virtualenv \
        --python /usr/bin/python /lambda_test \
        --always-copy \
        --no-site-packages

source /lambda_test/bin/activate

pip install --upgrade pip wheel
pip install --install-option="--prefix=/outputs/build/numpy" numpy
cp -rf /outputs/build/numpy/lib64/python2.7/site-packages/numpy /outputs/lambda-package

# Build OpenCV 3.1
(
	NUMPY=/outputs/lambda-package/numpy/core/include
	cd /outputs/build
	git clone https://github.com/Itseez/opencv.git
	cd opencv
	git checkout 3.1.0
	cmake										\
		-D CMAKE_BUILD_TYPE=RELEASE				\
		-D WITH_TBB=ON							\
		-D WITH_IPP=ON							\
		-D WITH_V4L=ON							\
		-D ENABLE_AVX=ON						\
		-D ENABLE_SSSE3=ON						\
		-D ENABLE_SSE41=ON						\
		-D ENABLE_SSE42=ON						\
		-D ENABLE_POPCNT=ON						\
		-D ENABLE_FAST_MATH=ON					\
		-D BUILD_EXAMPLES=OFF					\
		-D PYTHON2_NUMPY_INCLUDE_DIRS="$NUMPY"	\
		.
	make
)
cp /outputs/build/opencv/lib/cv2.so /outputs/lambda-package/cv2/__init__.so
cp -L /outputs/build/opencv/lib/*.so.3.1 /outputs/lambda-package/cv2
strip --strip-all /outputs/lambda-package/cv2/*
chrpath -r '$ORIGIN' /outputs/lambda-package/cv2/__init__.so
touch /outputs/lambda-package/cv2/__init__.py

# Copy template function and zip package
cp /outputs/template.py /outputs/lambda-package/lambda_function.py
cd /outputs/lambda-package
zip -r /outputs/lambda-package.zip *
