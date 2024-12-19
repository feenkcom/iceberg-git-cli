Class {
	#name : #PureGitPackageModified,
	#superclass : #Announcement,
	#instVars : [
		'name'
	],
	#category : #'Iceberg-Git-CLI-Pure-Code'
}

{ #category : #accessing }
PureGitPackageModified >> name [
	^ name
]

{ #category : #accessing }
PureGitPackageModified >> name: aString [
	name := aString
]

{ #category : #printing }
PureGitPackageModified >> printOn: aStream [
	super printOn: aStream.
	aStream nextPut: $(; nextPutAll: self name; nextPut: $) 
]
