# cocoapods-debug

A description of cocoapods-debug.

## Installation

    $ gem install cocoapods-debug

## Usage

```ruby

require 'cocoapods-debug'
plugin 'cocoapods-debug',:PodName =>['DebugSubspec']

target 'Demo' do
  pod 'PodName',:subspecs => ['DebugSubspec','ReleaseSubspec']
end


```
