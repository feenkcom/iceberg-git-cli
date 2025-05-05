Class {
	#name : #PureGitExamples,
	#superclass : #Object,
	#category : #'Iceberg-Git-CLI-Pure-Core'
}

{ #category : #examples }
PureGitExamples >> currentIceGitCliPlatform [
	<gtExample>
	<return: #IceGitCliPlatform>
	^ IceGitCliPlatform current
]
