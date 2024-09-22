"
I represent a specific file in a repository, defined by a relative path string.
"
Class {
	#name : #PureGitFile,
	#superclass : #PureGitRepositoryObject,
	#instVars : [
		'path'
	],
	#category : #'Iceberg-Git-CLI-Pure'
}

{ #category : #accessing }
PureGitFile >> fileReference [
	^ self repository location / self path
]

{ #category : #'as yet unclassified' }
PureGitFile >> gtLogFor: composite [
	<gtView>
	| timestampFormat |
	timestampFormat := ZTimestampFormat fromString: '2001-02-03 16:05'.
	^ composite columnedList
		title: 'History';
		priority: 40;
		tooltip: 'Commit log restricted to ' , self path;
		items: [ self log ];
		column: 'Commit' text: [ :commit | commit shortCommitId ] weight: 0.5;
		column: 'Timestamp' text: [ :commit | timestampFormat format: commit timestamp ] weight: 0.5;
		column: 'Author' text: [ :commit | commit author ];
		column: 'Comment' text: [ :commit | commit comment firstLineWithEllipsis ] weight: 2
]

{ #category : #accessing }
PureGitFile >> log [
	^ (self repository logFrom: 'HEAD' for: self path)
		collect: [ :each |
			PureGitFileCommit new
				copyFrom: each;
				path: self path;
				yourself ]
]

{ #category : #accessing }
PureGitFile >> path [
	^ path
]

{ #category : #accessing }
PureGitFile >> path: aPathString [
	path := aPathString
]

{ #category : #printing }
PureGitFile >> printOn: stream [
	super printOn: stream.
	stream nextPut: $(; nextPutAll: self path; nextPut: $)
]
