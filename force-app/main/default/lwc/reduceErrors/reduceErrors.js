export function reduceErrors(errors) {
    if (!Array.isArray(errors)) {
        errors = [errors];
    }

    return errors
        .filter((error) => !!error)
        .map((error) => {
            if (error.body && error.body.message) return error.body.message;
            if (error.message) return error.message;
            return error.statusText;
        })
        .join(", ");
}
