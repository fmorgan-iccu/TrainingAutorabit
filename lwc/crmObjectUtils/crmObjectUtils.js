const deepClone = (object) => {
    if (!object) {
        return null;
    }
    // This is meant for less complex objects; Not optimized for cloning larger objects.
    let clonedObject = JSON.parse(JSON.stringify(object));
    return clonedObject;
}

export {
    deepClone
};