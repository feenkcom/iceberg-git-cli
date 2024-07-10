Class {
	#name : #IceGitCliFiletreeReader,
	#superclass : #IceLibgitFiletreeReader,
	#category : #'Iceberg-Git-CLI-Core'
}

{ #category : #accessing }
IceGitCliFiletreeReader >> fileUtils [
	^ IceGitCliFiletreeFileUtils
]
