require "./spec_helper"

describe DiffHeight do
  # TODO: Write tests

  it "works" do
    max_iteration = 60
    DiffHeight::Fetcher.avg_distance_for_iteration_till(max_iteration, 2)

    f = DiffHeight::Fetcher.new
    f.max_iteration = max_iteration
    f.make_it_so
  end
end
