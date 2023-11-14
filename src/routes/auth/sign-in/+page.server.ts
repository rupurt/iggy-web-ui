import { fail, redirect } from '@sveltejs/kit';
import type { Actions } from './$types';
import { message, superValidate } from 'sveltekit-superforms/server';
import { z } from 'zod';
import { typedRoute } from '$lib/types/appRoutes';
import { fetchApi, getJson } from '$lib/api/fetchApi';
import { tokens } from '$lib/utils/tokens';

const schema = z.object({
  username: z.string().min(1),
  password: z.string().min(4)
});

export const load = async () => {
  const form = await superValidate(schema);

  return { form };
};

export const actions = {
  default: async ({ request, cookies, locals }) => {
    const form = await superValidate(request, schema);

    if (!form.valid) {
      return fail(400, { form });
    }

    const { password, username } = form.data;

    const result = await fetchApi({
      method: 'POST',
      path: '/users/login',
      body: { username, password }
    });

    if (!(result instanceof Response) || !result.ok) {
      return message(form, 'Username or password is not valid', { status: 403 });
    }

    const {
      tokens: { access_token, refresh_token }
    } = (await getJson(result)) as any;

    cookies.set(tokens.accessToken, access_token.token, {
      path: '/',
      httpOnly: true,
      sameSite: 'lax',
      secure: true,
      expires: new Date(access_token.expiry * 1000)
    });

    cookies.set(tokens.refreshToken, refresh_token.token, {
      path: '/',
      httpOnly: true,
      sameSite: 'lax',
      secure: true,
      expires: new Date(refresh_token.expiry * 1000)
    });

    throw redirect(302, typedRoute('/dashboard/overview'));
  }
} satisfies Actions;
