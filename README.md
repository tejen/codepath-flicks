# Project 1 - *Now Playing*

**Now Playing** is a movies app using the [The Movie Database API](http://docs.themoviedb.apiary.io/#).

Time spent: **14** hours spent in total

## User Stories

The following **required** functionality is complete:

- [X] User can view a list of movies currently playing in theaters from The Movie Database.
- [X] Poster images are loaded using the UIImageView category in the AFNetworking library.
- [X] User sees a loading state while waiting for the movies API.
- [X] User can pull to refresh the movie list.

The following **optional** features are implemented:

- [X] User sees an error message when there's a networking error.
- [X] Movies are displayed using a CollectionView instead of a TableView.
- [X] User can search for a movie.
- [X] All images fade in as they are loading.
- [X] Customize the UI.

The following **additional** features are implemented:

- [X] **Purchase tickets** from within the app!
- [X] **Check showtimes** from within the app!
- [X] **Watch trailers for each movie** from within the app! Loads a movie's IMDB page in a hidden UIWebView; then, javascript scrapes out the trailer video URL from the UIWebView, and the video at this URL is played back to the user. If IMDB doesn't have the trailer, **fallback** to Fandango trailer via Google's I'm Feeling Lucky algorithms.
- [X] **Auto Layout**
- [X] Progress Bar indicator for loading statuses
- [X] Table view **sorted by Rating**
- [X] Optionally switch from Table view to Collection View, **sorted by Popularity**)
- [X] Color-coded background (correlating to Popularity level) behind movie ratings.
- [X] Cancel button on search bar
- [X] Scrollable text field for long Movie Overviews in Table view
- [X] App Icon
- [X] Launch Screen with logo and Activity Indicator animation

Please list two areas of the assignment you'd like to **discuss further with your peers** during the next class (examples include better ways to implement something, how to extend your app in certain ways, etc):

1. Apple's Network Link Conditioner (see notes below)

2. Dynamically building base paths for TMDB images (see notes below)

## Video Walkthrough 

Here's a walkthrough of implemented user stories:

**(Watch this Video Walkthrough on [YouTube](http://youtu.be/pzkrRNaizEM) if the [GIF](http://x.tejen.net/bqn) lags or fails to download.)**

[<img src='https://img.tejen.net/46eb35bd84f89ac1c5da64ffdbe64316.png' title='Video Walkthrough' width='300' alt='Video Walkthrough' />](http://x.tejen.net/bqn)

```php
NOTE: GIF FILE SIZE IS VERY LARGE (60+ MB).
VIEWING THE YOUTUBE VIDEO INSTEAD IS RECOMMENDED.
The GIF and Video are identical. See Video link below...
```
Video: http://youtu.be/pzkrRNaizEM

GIF: [x.tejen.net/bqn](http://x.tejen.net/bqn)


<sup>**GitHub typically clones remote images to GitHub Camo servers for your security, a process which fails for large-filesize images.**</sup>

<sup>GIF created with [LiceCap](http://www.cockos.com/licecap/).</sup>

## Notes

Apple's Network Link Conditioner was absolutely indispensable during development. My network error messages are animated and tightly integrated with progress bar animations... developing this would have been a nightmare without the Conditioner. The Network Link Conditioner software should be endorsed, if not officially documented, in guidelines for this assignment.

TMDB could easily change the base paths for images. We should build the base paths using the separate APIs that they provide to this end. Furthermore, we should opt for being more decisive with image sizes... some peers were using full 500px width poster images and downscaling them into 60px UIImageViews, which resulted in an aliased appearance in the image.

Overall, though, this was a really really cool assignment! :)

## License

    Copyright ©2016 Tejen Hasmukh Patel

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

# Project 2 - *Now Playing*

**Now Playing** is a movies app displaying box office and top rental DVDs using [The Movie Database API](http://docs.themoviedb.apiary.io/#).

Time spent: **6** hours spent in total

## User Stories

The following **required** functionality is completed:

- [X] User can view movie details by tapping on a cell.
- [X] User can select from a tab bar for either **Now Playing** or **Top Rated** movies.
- [X] Customize the selection effect of the cell.

The following **optional** features are implemented:

- [X] For the large poster, load the low resolution image first and then switch to the high resolution image when complete.
- [X] Customize the navigation bar.

The following **additional** features are implemented:

- [X] Table/Collection State persists across Tab Bar tabbed views.

Please list two areas of the assignment you'd like to **discuss further with your peers** during the next class (examples include better ways to implement something, how to extend your app in certain ways, etc):

1. This project was a bad application of the Tab Bar method of navigation. Although it was seemingly not appropriate here, I do appreciate learning how the Tab Bar system works!

## Video Walkthrough 

Here's a walkthrough of implemented user stories:

<img src='' title='Video Walkthrough' width='' alt='Video Walkthrough' />

GIF created with [LiceCap](http://www.cockos.com/licecap/).

## Notes

Describe any challenges encountered while building the app.

## License

    Copyright ©2016 Tejen Hasmukh Patel

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
