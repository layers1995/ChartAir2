require 'test_helper'

class ReportControllerTest < ActionDispatch::IntegrationTest
  
  test "should get index" do
    get report_path
    assert_response :success
  end
  
  test "correct information should post" do
    get report_path
    post report_path, params: { report: { trip_id: 1, trip_rating: 2, trip_comments: "meh", fbo_rating: 1, fbo_comments: "cat" } }
    assert :success
  end
  
  test "missing information from report should refresh page" do
    get report_path
    post report_path, params: { report: { trip_id: 1, trip_comments: "meh", fbo_rating: 1, fbo_comments: "cat", trip_rating: "" } }
    assert_not flash.empty?
    assert_template 'report/index'
  end

end
