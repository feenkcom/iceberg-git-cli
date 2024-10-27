"
I am a commit restricted to one file defined by a relative path.
"
Class {
	#name : #PureGitFileCommit,
	#superclass : #PureGitCommit,
	#instVars : [
		'path'
	],
	#category : #'Iceberg-Git-CLI-Pure'
}

{ #category : #accessing }
PureGitFileCommit >> changesToParentDiffArgs [
	^ super changesToParentDiffArgs , { self path }
]

{ #category : #accessing }
PureGitFileCommit >> contents [
	| pathSegments entry |
	pathSegments := $/ split: self path.
	entry := self tree 
		entryAtPath: pathSegments 
		ifAbsent: [ FileDoesNotExistException signalWith: self path ].
	^ entry resolve text
]

{ #category : #accessing }
PureGitFileCommit >> contentsByFilesystem [
	^ (self fileSystem / self path) contents
]

{ #category : #'as yet unclassified' }
PureGitFileCommit >> gtContentsFor: composite [
	<gtView>
	| text |
	[ text := self contents ] 
		on: ZnCharacterEncodingError 
		do: [ ^ composite empty ].
	^ composite textEditor
		title: 'Contents';
		priority: 29;
		tooltip: 'Contents in this commit';
		glamorousCodeFontAndSize;
		text: [ text ]
]

{ #category : #accessing }
PureGitFileCommit >> log [
	^ (self repository queries log: { self commitId . '--' . self path })
		collect: [ :each |
			PureGitFileCommit new
				copyFrom: each;
				path: self path;
				yourself ]
]

{ #category : #accessing }
PureGitFileCommit >> path [
	^ path
]

{ #category : #accessing }
PureGitFileCommit >> path: aPathString [
	path := aPathString
]

{ #category : #printing }
PureGitFileCommit >> printDetailsOn: stream [
	stream nextPutAll: self id.
	stream space.
	stream nextPutAll: self path
]
