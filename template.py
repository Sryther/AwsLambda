import cv2
import os
import boto3
import uuid

s3 = boto3.client('s3')
def lambda_handler(event, context):
	print "OpenCV installed version:", cv2.__version__
	s3.download_file('imagesdevops', 'lena.jpeg', '/tmp/lena.jpeg')
	
	image = cv2.imread('/tmp/lena.jpeg')

	gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
	edged = cv2.Canny(gray, 30, 200)
	imagename = 'target-%s.jpg' % (uuid.uuid4(),)
	cv2.imwrite('/tmp/'+imagename,edged)

	s3.upload_file('/tmp/'+imagename, 'imagesdevops', imagename)


	return "It works!"

if __name__ == "__main__":
	lambda_handler(42, 42)
