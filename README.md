## Original project here:

http://cnanney.com/journal/code/apple-style-counter-revisited/

## Notes

This is a complete re-write.  Only thing currently supported is increment, however multiple increments during animation are cached / handled by way of animating a copy, then checking at the end of animation and animating again if flagged dirty.  Appears to handle massive amounts of touch events without any noticeable lag.  I've tried to keep things as zippy as possible, if somebody wants to help me out or has an idea of making it better, pull requests welcome.

## License

MIT
