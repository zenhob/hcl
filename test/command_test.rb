require 'test_helper'
class CommandTest < Test::Unit::TestCase
  include HCl::Commands
  include HCl::Utility

  def setup
    @settings = {}
  end

  # the current_time utility method needs to be deterministic
  def current_time
    'high noon'
  end

  # stub settings helpers
  def write_settings; end
  def read_settings
    @settings
  end

  def test_tasks
    HCl::Task.expects(:all).returns([HCl::Task.new(
      id:123,
      name: 'Dev',
      project: HCl::Project.new(id:456, name:'App', client:'Bob', code:'b')
    )])
    result = tasks
    assert_equal "456 123\tBob - [b] App - Dev", result
  end

  def test_show
    HCl::DayEntry.expects(:all).returns([HCl::DayEntry.new({
      hours:'2.06',
      notes: 'hi world',
      project: 'App'
    })])
    result = show
    assert_equal \
      "\t2:03\tApp: hi world\n\t-------------\n\t2:03\ttotal (as of high noon)\n",
      result
  end

  def test_aliases
    HCl::Task.expects(:all).returns([HCl::Task.new(
      id:123,
      name: 'Dev',
      project: HCl::Project.new(id:456, name:'App', client:'Bob', code:'b')
    )])
    result = send :alias, *%w[ hcl 456 123 ]
    assert_equal '456 123', @settings['task.hcl']

    result = aliases
    assert_equal ["@hcl"], result

    result = unalias 'hcl'
    assert !@settings.key?('task.hcl'), 'hcl alias is no longer defined'
  end

  def test_start
    task = HCl::Task.new(
      id:123,
      name: 'Dev',
      project: HCl::Project.new(id:456, name:'App', client:'Bob', code:'b')
    )
    HCl::Task.expects(:find).with('456','123').returns(task)
    task.expects(:start).with(starting_time:nil, note:'do stuff')
    start *%w[ 456 123 do stuff ]
  end

  def test_stop
    entry = stub
    HCl::DayEntry.expects(:with_timer).returns(entry)
    entry.expects(:append_note).with('all done')
    entry.expects(:toggle)
    stop 'all done'
  end

  def test_resume
    entry = stub
    HCl::DayEntry.expects(:last).returns(entry)
    entry.expects(:toggle)
    resume
  end

  def test_cancel
    entry = stub
    HCl::DayEntry.expects(:with_timer).returns(entry)
    entry.expects(:cancel).returns(true)
    cancel
  end

  def test_note
    entry = stub
    HCl::DayEntry.expects(:with_timer).returns(entry)
    entry.expects(:append_note).with('hi world')
    note 'hi world'
  end

end
