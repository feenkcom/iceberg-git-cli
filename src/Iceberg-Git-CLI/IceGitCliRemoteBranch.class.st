Class {
	#name : #IceGitCliRemoteBranch,
	#superclass : #IceRemoteBranch,
	#instVars : [
		'commit'
	],
	#category : #'Iceberg-Git-CLI-Core'
}

{ #category : #accessing }
IceGitCliRemoteBranch >> commit [
	| gitId |
	commit ifNotNil: [ ^ commit ].
	gitId := repository lookupRemoteBranch: self name.
	^ commit := repository commitFromGitCommit: gitId
]

{ #category : #accessing }
IceGitCliRemoteBranch >> name [
	^ self fullname withoutPrefix: self prefix
]

{ #category : #accessing }
IceGitCliRemoteBranch >> prefix [
	^ 'refs/remotes/'
]

{ #category : #accessing }
IceGitCliRemoteBranch >> remoteName [
	^ (self fullname substrings: '/') third
]
