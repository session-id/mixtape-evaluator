import csv
max_map_size = 100
num_days_before_release = 60
num_days_after_release = 30
count_metrics = []
delta_metrics = []

def get_metrics_strings(fieldnames):
	for name in fieldnames:
		if name.endswith('_t'):
			count_metrics.append(name)
		elif name.endswith('_d'):
			delta_metrics.append(name)

def read_csv_file():
	artist_map = {}
	with open('challenge_data.csv') as csvfile:
		reader = csv.DictReader(csvfile)
		# initialize our set of metric str identifiers
		get_metrics_strings(reader.fieldnames)
		# metrics_strings = set(reader.fieldnames)
		for row in reader:
			if len(artist_map) > max_map_size:
				break
			metrics_map = {}
			for key, value in row.iteritems():
				if key != "ArtistId" and key != "Day":
					try:
						value = float(value)
					except ValueError:
						if not "-" in value:
							value = 0
					metrics_map[key] = value
			curr_artist_id = row['ArtistId']
			if not(curr_artist_id in artist_map):
				artist_map[curr_artist_id] = {}
			artist_map[curr_artist_id][row['Day']] = metrics_map
			if row['IsReleaseDay'] == '1':
				if not ('Releases' in artist_map[curr_artist_id]):
					artist_map[curr_artist_id]['Releases'] = []
				artist_map[curr_artist_id]['Releases'].append(int(row['Day']))

	return artist_map

def compute_feature_vector(day_map, release_day):
	start_date = release_day - num_days_before_release
	end_date = release_day - 1

	try:
		start_metric_map = day_map[str(start_date)]
		end_metric_map = day_map[str(end_date)]
	except KeyError:
		return None

	count_vector = []

	for count_string_label in count_metrics:
		# create a difference element for the vector
		end_value = end_metric_map[count_string_label]
		start_value = start_metric_map[count_string_label]
		difference = end_value - start_value
		if difference < 0:
			difference = 0
			#print(count_string_label + "... difference: " + str(difference) + ", " + "start date: " + str(start_date) + "->" + str(start_value) +", end_date: " + str(end_date) + "->" + str(end_value))
		count_vector.append(difference)

	return count_vector

def compute_y_label(day_map, release_day):
	query_date = release_day + num_days_after_release
	try:
		query_point_video_views = day_map[str(query_date)]['YouTube_ChannelViews_t']
		release_day_video_views = day_map[str(release_day)]['YouTube_ChannelViews_t']
	except KeyError:
		return None
	if query_point_video_views == 0 or release_day_video_views == 0:
		return None
	return [query_point_video_views - release_day_video_views]



def create_feature_vector(artist_map):
	training_examples_list = []
	for artist_id, day_map in artist_map.iteritems():
		if 'Releases' in day_map:
			for release_day in day_map['Releases']:
				x_vector = compute_feature_vector(day_map, release_day)
				y_label = compute_y_label(day_map, release_day)
				if x_vector != None and y_label != None and y_label[0] != 0:
					training_examples_list.append(x_vector + y_label)
	return training_examples_list

def write_csv_file(training_examples_list):
	csvfile = open('training_data.csv', 'w')
	writer = csv.writer(csvfile, delimiter=',', quotechar='|', quoting=csv.QUOTE_MINIMAL)
	for training_ex in training_examples_list:
		writer.writerow(training_ex)
	csvfile.close()


artist_map = read_csv_file()
training_examples_list = create_feature_vector(artist_map)
#print "training examples " + str(training_examples_list)
write_csv_file(training_examples_list)
#print "Initial artist map" + str(artist_map)