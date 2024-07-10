Class {
	#name : #GtGitCliCommandError,
	#superclass : #GtGitError,
	#instVars : [
		'stderr',
		'args',
		'exitCode'
	],
	#category : #'Iceberg-Git-CLI-Support'
}

{ #category : #accessing }
GtGitCliCommandError >> args [
	^ args ifNil: [ #() ]
]

{ #category : #accessing }
GtGitCliCommandError >> args: anObject [
	args := anObject
]

{ #category : #accessing }
GtGitCliCommandError >> commandLine [
	^ Character space join: ({ 'git' } , self args)
]

{ #category : #accessing }
GtGitCliCommandError >> errorLine [
	^ self stderr detect: [ :line | line beginsWith: 'ERROR' ] ifNone: [ nil ]
]

{ #category : #accessing }
GtGitCliCommandError >> exitCode [
	^ exitCode
]

{ #category : #accessing }
GtGitCliCommandError >> exitCode: anObject [
	exitCode := anObject
]

{ #category : #accessing }
GtGitCliCommandError >> messageText [
	^ messageText ifNil: [ 
		messageText := String streamContents: [ :out |
			out 
				nextPutAll: self commandLine;
				nextPutAll: ' failed.'.
			self errorLine ifNotNil: [ :line | 
				out 
					space; 
					nextPutAll: self errorLine ] ] ]
]

{ #category : #accessing }
GtGitCliCommandError >> stderr [
	^ stderr ifNil: [ #() ]
]

{ #category : #accessing }
GtGitCliCommandError >> stderr: anObject [
	stderr := anObject
]
