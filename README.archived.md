# Cascading.JRuby [![Build Status](https://secure.travis-ci.org/mrwalker/cascading.jruby.png)](http://travis-ci.org/mrwalker/cascading.jruby)

cascading.jruby is a DSL for [Cascading](http://www.cascading.org/), which is a dataflow API written in Java.  With cascading.jruby, Ruby programmers can rapidly script efficient MapReduce jobs for Hadoop.

To give you a quick idea of what a cascading.jruby job looks like, here's word count:

```ruby
require 'rubygems'
require 'cascading'

input_path = ARGV.shift || (raise 'input_path required')

cascade 'wordcount', :mode => :local do
  flow 'wordcount' do
    source 'input', tap(input_path)

    assembly 'input' do
      split_rows 'line', 'word', :pattern => /[.,]*\s+/, :output => 'word'
      group_by 'word' do
        count
      end
    end

    sink 'input', tap('output/wordcount', :sink_mode => :replace)
  end
end.complete
```

cascading.jruby provides a clean Ruby interface to Cascading, but doesn't attempt to add abstractions on top of it.  Therefore, you should be acquainted with the [Cascading](http://docs.cascading.org/cascading/2.0/userguide/html/) [API](http://docs.cascading.org/cascading/2.0/javadoc/) before you begin.

For operations you can apply to your dataflow within a pipe assembly, see the [Assembly](http://rubydoc.info/gems/cascading.jruby/0.0.10/Cascading/Assembly) class.  For operations available within a block passed to a group_by, union, or join, see the [Aggregations](http://rubydoc.info/gems/cascading.jruby/0.0.10/Cascading/Aggregations) class.

Note that the Ruby code you write merely constructs a Cascading job, so no JRuby runtime is required on your cluster.  This stands in contrast with writing [Hadoop streaming jobs in Ruby](http://www.quora.com/How-do-the-different-options-for-Ruby-on-Hadoop-compare).  To run cascading.jruby applications on a Hadoop cluster, you must use [Jading](https://github.com/etsy/jading) to package them into a job jar.

cascading.jruby has been tested on JRuby versions 1.2.0, 1.4.0, 1.5.3, 1.6.5, and 1.6.7.2.
