require 'helper'

class TestOffGuthub < Test::Unit::TestCase
  def setup
    @local_list = OffGithub::GemList.new %w(foo-bar qux-quux foo-bar-baz baz-baz corge grault-garble-warg_fred plugh-thud xyzzy)
    @github_list = OffGithub::GemList.new %w(foo-bar qux-quux xxx-xxx baz-baz grault-garble-warg_fred plugh-thud)
    @gemcutter_list = OffGithub::GemList.new %w(corge quux xxx bar garble-warg_fred baz xyzzy)
    @investigator = OffGithub::GemInvestigator.new(@local_list, @gemcutter_list, @github_list)
  end
    
  should "identify gems as github gems" do
    assert_same_elements %w(foo-bar qux-quux baz-baz grault-garble-warg_fred plugh-thud), @investigator.github_suspects
  end
  
  should "identify corresponding gemcutter gems" do
    assert_same_elements %w(bar quux baz garble-warg_fred) + [nil], @investigator.found_matches
  end
  
  should "relate gems correctly" do
    assert_same_elements [["foo-bar", "bar"], 
                          ["qux-quux", "quux"], 
                          ["baz-baz", "baz"], 
                          ["grault-garble-warg_fred", "garble-warg_fred"],
                          ["plugh-thud", nil]], @investigator.relations.to_a
  end
  
  should "find github gems not found in gemcutter" do
    assert_same_elements %w(plugh-thud), @investigator.will_not_be_migrated
  end
end
