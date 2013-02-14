require 'spec_helper'

describe Album do
  fixtures :pictures, :albums, :groups, :group_users, :shared_tabs
  before(:each) do
    @album = Album.new(:name => 'Somenmae', :user_id => 1)
  end

  it "should be invalid without name" do
    @album.name = nil
    @album.should_not be_valid
    @album.name = "Some name"
    @album.should be_valid
  end
  
  it "should be invalid if name having more than 20 characters" do
    @album.name = "n"*21
    @album.should_not be_valid
    @album.name = "z"*20
    @album.should be_valid
  end
  
  it "should return the albums 9 pictures" do
    @album.show_photo_per_album.length.should eql(0)
    pics = pictures(:one)
    Picture.stub!(:find).and_return(pics)
    @album.show_photo_per_album.should_not be_nil
  end

   it "should return all shared pictures" do
    @album.shared_pictures(1,1).length.should eql(0)
    pics = pictures(:one)
    @album.shared_pictures(1,1).should_not be_nil
    Picture.stub!(:find_by_sql).and_return([])
    @album.shared_pictures(2,1).length.should eql(0)
    Picture.stub!(:find_by_sql).and_return([pics])
    @album.shared_pictures(2,1).length.should eql(1)
  end
  

end
