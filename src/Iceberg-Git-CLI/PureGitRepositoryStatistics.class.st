"
I compute a number of statistics about a git repository
"
Class {
	#name : #PureGitRepositoryStatistics,
	#superclass : #PureGitRepositoryObject,
	#instVars : [
		'log'
	],
	#category : #'Iceberg-Git-CLI-Pure'
}

{ #category : #private }
PureGitRepositoryStatistics >> describeTimestamp: timestamp [
	| duration dateFormat |
	dateFormat := ZTimestampFormat isoDate.
	duration := ZTimestamp now - timestamp.
	^ String streamContents: [ :out |
		dateFormat format: timestamp on: out.
		out nextPutAll: ' - '.
		out nextPutAll: (self renderDuration: duration).
		out nextPutAll: ' ago' ]
]

{ #category : #accessing }
PureGitRepositoryStatistics >> firstCommit [
	^ self log last
]

{ #category : #accessing }
PureGitRepositoryStatistics >> lastCommit [
	^ self log first
]

{ #category : #accessing }
PureGitRepositoryStatistics >> log [
	^ log ifNil: [ log := self repository log toArray wait ]
]

{ #category : #printing }
PureGitRepositoryStatistics >> printOn: stream [
	super printOn: stream.
	stream nextPut: $(.
	self repository location printOn: stream.
	stream nextPut: $)
]

{ #category : #private }
PureGitRepositoryStatistics >> renderDuration: duration [
	duration < 1 day
		ifTrue: [ ^ duration hours pluralize: 'hour' ].
	duration < 1 week
		ifTrue: [ ^ duration days pluralize: 'day' ].
	duration < 30 days
		ifTrue: [ ^ duration days // 7 pluralize: 'week' ].
	duration < 356 days
		ifTrue: [ ^ duration days // 30 pluralize: 'month' ].
	^ duration days // 356 pluralize: 'year'
]

{ #category : #accessing }
PureGitRepositoryStatistics >> worktreeDescription [
	| files directories |
	files := self repository location allFiles size - (self repository location / '.git') allFiles size.
	directories := self repository location allDirectories size - (self repository location / '.git') allDirectories size.
	^ String streamContents: [ :out |
		out nextPutAll: (files pluralize: 'file').
		out nextPutAll: ' in '.
		out nextPutAll: (directories pluralize: 'directory') ]
]
