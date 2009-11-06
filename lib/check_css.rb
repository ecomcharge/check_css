# Mostly stolen from http://code.sixapart.com/svn/CSS-Cleaner/trunk/lib/CSS/Cleaner.pm
class CheckCSS
  
  def self.clean?(raw)
    new(raw).clean?
  end
  
  def self.dirty?(raw)
    new(raw).dirty?
  end
  
  def initialize(raw)
    @raw = raw
  end
  
  def clean?
    !dirty?
  end
  
  def dirty?
    stripped = strip_comments_and_newlines(@raw)
    suspect_comments?(@raw) or suspect_css?(stripped)
  end
  
private
  
  # Tests for the following:
  # * a// comment immediately following a letter
  # * a/* comment immediately following a letter
  # * /*/ --> hack attempt, IMO
  def suspect_comments?(text)
    text =~ %r{(\/\*\/)|(\w\/\/*\*)|(\/\*\/)}
  end
  
  def suspect_css?(text)
    [
      %r{(\bdata:\b|eval|cookie|\bwindow\b|\bparent\b|\bthis\b)}i, # suspicious javascript-type words
      %r{behaviou?r|expression|moz-binding|@import|@charset|(java|vb)?script|[\<]|\\\w}i,
      %r{(\<.+>)}, # back slash, html tags,
      %r{[\x7f-\xff]}, # high bytes -- suspect
      %r{[\x00-\x08\x0B\x0C\x0E-\x1F]}, #low bytes -- suspect
      %r{&\#}, # bad charset
    ].any? do |regex|
      text =~ regex
    end
  end
  
  # Filter out any /* ... */ or newlines
  def strip_comments_and_newlines(text)
    text.gsub(/(\/\*.*?\*\/)|\r\n|\n/, "") 
  end
end